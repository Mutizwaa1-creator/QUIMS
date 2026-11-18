<?php
require_once __DIR__ . '/helpers.php';

if (!empty($_SESSION['user_id'])) {
    try {
        $userTable = ($_SESSION['user_type'] ?? 'staff') === 'general' ? 'general_users' : 'users';
        $stmt = $db->prepare("UPDATE {$userTable} SET last_logout = NOW() WHERE id = ?");
        $stmt->execute([$_SESSION['user_id']]);

        if ($userTable === 'users') {
            $assistantStmt = $db->prepare(
                'UPDATE assistants a
                 INNER JOIN users u ON LOWER(TRIM(u.email)) = LOWER(TRIM(a.email))
                 SET a.status = "offline"
                 WHERE u.id = ?'
            );
            $assistantStmt->execute([$_SESSION['user_id']]);
        }
    } catch (PDOException $e) {
        error_log('Failed to record logout time: ' . $e->getMessage());
    }
}

$_SESSION = [];
session_destroy();

if (ini_get('session.use_cookies')) {
    $params = session_get_cookie_params();
    setcookie(
        session_name(),
        '',
        time() - 42000,
        $params['path'],
        $params['domain'],
        $params['secure'],
        $params['httponly']
    );
}

http_response_code(200);
sendJson(['success' => true]);
