<?php
// Ensure secure session cookie params before starting session
$secure = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off');
if (PHP_VERSION_ID >= 70300) {
    session_set_cookie_params([
        'lifetime' => 0,
        'path' => '/',
        'domain' => '',
        'secure' => $secure,
        'httponly' => true,
        'samesite' => 'Lax'
    ]);
} else {
    session_set_cookie_params(0, '/', '', $secure, true);
}
session_start();
header('Content-Type: application/json');


$host = '127.0.0.1';
$db   = 'iecms';
$user = 'root';
$pass = '';
$charset = 'utf8mb4';

$dsn = "mysql:host=$host;dbname=$db;charset=$charset";

$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES   => false,
];

try {
    $pdo = new PDO($dsn, $user, $pass, $options);
} catch (PDOException $e) {
    echo json_encode(['error' => 'Database connection failed.']);
    exit;
}

function startNewLoginSession() {
    if (session_status() === PHP_SESSION_ACTIVE) {
        session_write_close();
    }
    unset($_COOKIE[session_name()]);
    session_id('');
    session_start();
    $_SESSION = [];
}

function invalidCredentialsMessage($isAssistantIdLogin, $isNationalIdLogin) {
    if ($isAssistantIdLogin) {
        return 'Wrong assistant ID or passkey';
    }
    if ($isNationalIdLogin) {
        return 'Wrong National ID or passkey';
    }
    return 'Wrong email or password';
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['error' => 'Invalid request method']);
    exit;
}



$identifier = trim((string)($_POST['identifier'] ?? ''));
$email = strtolower($identifier);
$isAssistantIdLogin = preg_match('/^[1-9][0-9]*$/', $identifier) === 1;
$isNationalIdLogin = preg_match('/^(?=.*[A-Z])(?=.*[0-9])[A-Z0-9]{8,14}$/i', $identifier) === 1;
$password = trim($_POST['password'] ?? '');

if ($email === '' || $password === '') {
    echo json_encode(['error' => 'Please provide your email, assistant ID, or National ID and your password or passkey']);
    exit;
}

if (!$isAssistantIdLogin && !$isNationalIdLogin && !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode(['error' => 'Enter a valid email address, assistant ID, or National ID']);
    exit;
}

try {
    $nationalIdSigner = null;
    if ($isAssistantIdLogin) {
        $stmt = $pdo->prepare(
            "SELECT u.*, COALESCE(NULLIF(u.full_name, ''), a.name) AS login_name
             FROM assistants a
             INNER JOIN users u ON LOWER(TRIM(u.email)) = LOWER(TRIM(a.email))
             WHERE a.id = ?
             LIMIT 1"
        );
        $stmt->execute([$identifier]);
        $user = $stmt->fetch();
    } elseif ($isNationalIdLogin) {
        $signerStmt = $pdo->prepare(
            "SELECT id, full_name, passkey_hash, status
             FROM general_users
             WHERE UPPER(TRIM(national_id)) = ?
               AND passkey_hash IS NOT NULL AND passkey_hash <> ''
             ORDER BY id ASC
             LIMIT 2"
        );
        $signerStmt->execute([strtoupper($identifier)]);
        $signers = $signerStmt->fetchAll();
        if (count($signers) !== 1 || ($signers[0]['status'] ?? '') !== 'active') {
            echo json_encode(['error' => 'Wrong National ID or passkey']);
            exit;
        }
        $nationalIdSigner = $signers[0];

        $staffStmt = $pdo->prepare(
            "SELECT u.*, COALESCE(NULLIF(u.full_name, ''), a.name) AS login_name
             FROM users u
             INNER JOIN assistants a ON LOWER(TRIM(u.email)) = LOWER(TRIM(a.email))
             WHERE LOWER(TRIM(COALESCE(NULLIF(u.full_name, ''), a.name))) = LOWER(TRIM(?))
               AND LOWER(u.role) IN ('admin', 'supervisor', 'assistant')
             LIMIT 2"
        );
        $staffStmt->execute([$nationalIdSigner['full_name']]);
        $staffAccounts = $staffStmt->fetchAll();
        if (count($staffAccounts) !== 1) {
            echo json_encode(['error' => 'Wrong National ID or passkey']);
            exit;
        }
        $user = $staffAccounts[0];
    } else {
        $stmt = $pdo->prepare("SELECT * FROM users WHERE email = ? LIMIT 1");
        $stmt->execute([$email]);
        $user = $stmt->fetch();
    }

    if (!$user && !$isAssistantIdLogin && !$isNationalIdLogin) {
        $generalStmt = $pdo->prepare("SELECT * FROM general_users WHERE email = ? LIMIT 1");
        $generalStmt->execute([$email]);
        $generalUser = $generalStmt->fetch();
        if (!$generalUser) {
            echo json_encode(['error' => invalidCredentialsMessage(false, false)]);
            exit;
        }
        if (($generalUser['status'] ?? 'active') !== 'active') {
            echo json_encode(['error' => 'This account is not active. Please contact an administrator.']);
            exit;
        }
        if (!password_verify($password, $generalUser['password_hash'])) {
            echo json_encode(['error' => 'Wrong email or password.']);
            exit;
        }
        $pdo->prepare("UPDATE general_users SET failed_attempts = 0, blocked_until = NULL, last_login = NOW() WHERE id = ?")
            ->execute([$generalUser['id']]);
        startNewLoginSession();
        $_SESSION['user_id'] = $generalUser['id'];
        $_SESSION['user_type'] = 'general';
        $_SESSION['user_name'] = $generalUser['full_name'];
        $_SESSION['role'] = 'general_user';
        echo json_encode([
            'greeting' => "Welcome, {$generalUser['full_name']}!",
            'redirect' => 'user-dashboard.php',
            'tabSession' => session_id()
        ]);
        exit;
    }

    if (!$user) {
        echo json_encode(['error' => invalidCredentialsMessage($isAssistantIdLogin, $isNationalIdLogin)]);
        exit;
    }
    if (empty($user['full_name'])) {
        $user['full_name'] = $user['login_name'] ?? '';
    }


    if ((int)$user['is_permanent_block'] === 1) {
        echo json_encode([
            'permanent' => true,
            'role'      => strtoupper($user['role']),
            'userName'  => $user['full_name']
        ]);
        exit;
    }



    if (!empty($user['blocked_until'])) {
        $blockedUntil = strtotime($user['blocked_until']);
        $now = time();

        if ($blockedUntil > $now) {
            echo json_encode([
                'error' => 'Too many attempts. Try again later.',
                'blockTime' => $blockedUntil - $now,
                'userName' => $user['full_name']
            ]);
            exit;
        } else {

            $pdo->prepare("UPDATE users SET failed_attempts = 0, blocked_until = NULL WHERE id = ?")
                ->execute([$user['id']]);
        }
    }


    $credentialsAreValid = false;
    if ($isNationalIdLogin) {
        $credentialsAreValid = password_verify($password, (string)$nationalIdSigner['passkey_hash']);
    } elseif ($isAssistantIdLogin) {
        $passkeyStmt = $pdo->prepare(
            "SELECT passkey_hash
             FROM general_users
             WHERE LOWER(TRIM(full_name)) = LOWER(TRIM(?))
               AND passkey_hash IS NOT NULL AND passkey_hash <> ''
             ORDER BY id ASC"
        );
        $passkeyStmt->execute([$user['full_name']]);
        foreach ($passkeyStmt->fetchAll(PDO::FETCH_COLUMN) as $passkeyHash) {
            if (password_verify($password, $passkeyHash)) {
                $credentialsAreValid = true;
                break;
            }
        }
    } else {
        $credentialsAreValid = password_verify($password, $user['password_hash']);
    }

    if (!$credentialsAreValid) {

        $attempts = (int)$user['failed_attempts'] + 1;
        $credentialError = invalidCredentialsMessage($isAssistantIdLogin, $isNationalIdLogin) . '.';


        if ($attempts >= 3 && $attempts < 6) {
            $pdo->prepare("
                UPDATE users 
                SET failed_attempts = ?, 
                    blocked_until = DATE_ADD(NOW(), INTERVAL 1 MINUTE) 
                WHERE id = ?
            ")->execute([$attempts, $user['id']]);

            echo json_encode([
                'error' => $isAssistantIdLogin || $isNationalIdLogin
                    ? invalidCredentialsMessage($isAssistantIdLogin, $isNationalIdLogin) . '. Try again in 60 seconds.'
                    : 'Wrong email or password. Try again in 60 seconds.',
                'blockTime' => 60,
                'userName' => $user['full_name']
            ]);
            exit;
        }


        if ($attempts >= 6) {
            $pdo->prepare("UPDATE users SET is_permanent_block = 1 WHERE id = ?")
                ->execute([$user['id']]);

            echo json_encode([
                'permanent' => true,
                'role' => strtoupper($user['role']),
                'userName' => $user['full_name']
            ]);
            exit;
        }

        $pdo->prepare("UPDATE users SET failed_attempts = ? WHERE id = ?")
            ->execute([$attempts, $user['id']]);

        echo json_encode([
            'error' => $credentialError,
            'userName' => $user['full_name']
        ]);
        exit;
    }


    $pdo->prepare("
        UPDATE users 
        SET failed_attempts = 0, 
            blocked_until = NULL, 
            last_login = NOW(),
            last_activity = NOW()
        WHERE id = ?
    ")->execute([$user['id']]);

    $pdo->prepare('UPDATE assistants SET status = "online" WHERE LOWER(TRIM(email)) = LOWER(TRIM(?))')
        ->execute([$user['email']]);

    startNewLoginSession();
    $_SESSION['user_id']   = $user['id'];
    $_SESSION['user_type'] = 'staff';
    $_SESSION['user_name'] = $user['full_name'];
    $_SESSION['role']      = $user['role'];


    $hour = (int)date('H');

    if ($hour < 12) {
        $greeting = "Good morning, {$user['full_name']}!";
    } elseif ($hour < 18) {
        $greeting = "Good afternoon, {$user['full_name']}!";
    } else {
        $greeting = "Good evening, {$user['full_name']}!";
    }



    switch (strtolower($user['role'])) {
        case 'admin':
            $redirect = 'admin/index.php';
            break;
        case 'supervisor':
            $redirect = 'supervisor/supervisor-dashboard.php';
            break;
        case 'assistant':
            $redirect = 'assistant/assistant-dashboard.php';
            break;
        default:
            $redirect = 'user-dashboard.php';
            break;
    }
    if (
        ($_POST['returnTo'] ?? '') === 'vsp/index.php'
        && in_array(strtolower((string)$user['role']), ['admin', 'supervisor', 'assistant'], true)
    ) {
        $redirect = 'vsp/index.php';
    }
    if (
        ($isAssistantIdLogin || $isNationalIdLogin)
        && in_array(strtolower((string)$user['role']), ['admin', 'supervisor', 'assistant'], true)
    ) {
        $redirect = 'vsp/index.php';
    }

    echo json_encode([
        'greeting' => $greeting,
        'redirect' => $redirect,
        'tabSession' => session_id()
    ]);
    exit;
} catch (Exception $e) {
    echo json_encode(['error' => 'Server error occurred.']);
    exit;
}
