<?php
require_once __DIR__ . '/helpers.php';

function requestGeminiGeneration($model, $apiKey, $payload) {
    $endpoint = 'https://generativelanguage.googleapis.com/v1beta/models/'
        . rawurlencode($model) . ':generateContent?key=' . rawurlencode($apiKey);
    $curl = curl_init($endpoint);
    curl_setopt_array($curl, [
        CURLOPT_POST => true,
        CURLOPT_POSTFIELDS => $payload,
        CURLOPT_HTTPHEADER => ['Content-Type: application/json'],
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => 30
    ]);
    $body = curl_exec($curl);
    $error = curl_error($curl);
    $status = (int)curl_getinfo($curl, CURLINFO_HTTP_CODE);
    curl_close($curl);

    return ['body' => $body, 'error' => $error, 'status' => $status];
}

$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$action = $_GET['action'] ?? '';
$isGenerateRequest = $_SERVER['REQUEST_METHOD'] === 'POST'
    && (strpos($path, '/generate') !== false || $action === 'generate');
if ($isGenerateRequest) {
    requireRole(['admin', 'supervisor', 'assistant']);
} else {
    requireAdminOrSupervisor();
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (strpos($path, '/generate') !== false || $action === 'generate') {
        $data = json_decode(file_get_contents('php://input'), true) ?: [];
        $prompt = $data['prompt'] ?? ($data['message'] ?? null);

        if (!is_string($prompt) || trim($prompt) === '') {
            http_response_code(400);
            echo json_encode(['error' => 'Missing prompt in request body']);
            exit;
        }

        $apiKey = getenv('GEMINI_API_KEY') ?: ($_ENV['GEMINI_API_KEY'] ?? '');
        if (!$apiKey) {
            http_response_code(503);
            echo json_encode(['error' => 'Gemini is not configured on the server']);
            exit;
        }

        if (!function_exists('curl_init')) {
            http_response_code(500);
            echo json_encode(['error' => 'PHP cURL is not enabled. Enable extension=curl in php.ini and restart Apache.']);
            exit;
        }

        $model = getenv('GEMINI_MODEL') ?: ($_ENV['GEMINI_MODEL'] ?? 'gemini-3.5-flash-lite');
        $model = preg_replace('/^models\//', '', trim($model));
        if (!$model) {
            $model = 'gemini-3.5-flash-lite';
        }
        $fullPrompt = "Answer the user's request completely and directly. Include all necessary explanation and actionable steps. Do not impose an arbitrary line limit, omit important details, or stop mid-sentence. Use headings or alternatives only when they help answer the request.\n\nUser request:\n" . trim($prompt);
        $payload = json_encode([
            'contents' => [[
                'parts' => [['text' => $fullPrompt]]
            ]],
            'generationConfig' => [
                'temperature' => 0.2,
                'maxOutputTokens' => 4096
            ]
        ]);

        $result = requestGeminiGeneration($model, $apiKey, $payload);
        $responseBody = $result['body'];
        $curlError = $result['error'];
        $httpStatus = $result['status'];

        if ($responseBody === false || $curlError) {
            http_response_code(502);
            echo json_encode(['error' => 'Unable to reach Gemini: ' . ($curlError ?: 'unknown network error')]);
            exit;
        }

        $response = json_decode($responseBody, true);
        $providerMessage = (string)($response['error']['message'] ?? '');
        $isTemporaryOverload = in_array($httpStatus, [429, 503], true)
            && preg_match('/high demand|overload|temporarily unavailable|try again later/i', $providerMessage);
        $fallbackModel = 'gemini-3.5-flash-lite';
        if ($isTemporaryOverload && $model !== $fallbackModel) {
            $fallbackResult = requestGeminiGeneration($fallbackModel, $apiKey, $payload);
            if ($fallbackResult['body'] === false || $fallbackResult['error']) {
                http_response_code(502);
                echo json_encode(['error' => 'Gemini is temporarily busy. Please try again shortly.']);
                exit;
            }
            $result = $fallbackResult;
            $responseBody = $result['body'];
            $httpStatus = $result['status'];
            $model = $fallbackModel;
            $response = json_decode($responseBody, true);
            $providerMessage = (string)($response['error']['message'] ?? '');
        }

        if ($httpStatus < 200 || $httpStatus >= 300) {
            if (in_array($httpStatus, [429, 503], true)
                && preg_match('/high demand|overload|temporarily unavailable|try again later/i', $providerMessage)) {
                http_response_code(503);
                echo json_encode(['error' => 'Gemini is temporarily busy. Please try again shortly.']);
                exit;
            }
            http_response_code(502);
            echo json_encode(['error' => ($providerMessage ?: 'Gemini request failed') . ' Model: ' . $model]);
            exit;
        }

        $candidate = $response['candidates'][0] ?? [];
        if (($candidate['finishReason'] ?? '') === 'MAX_TOKENS') {
            http_response_code(502);
            echo json_encode(['error' => 'Gemini reached its response limit before completing the answer. Please shorten the request and try again.']);
            exit;
        }
        $parts = $candidate['content']['parts'] ?? [];
        $text = implode('', array_map(
            static function ($part) {
                return is_string($part['text'] ?? null) ? $part['text'] : '';
            },
            $parts
        ));
        if ($text === '') {
            http_response_code(502);
            echo json_encode(['error' => 'Gemini returned an empty response']);
            exit;
        }
        echo json_encode([
            'id' => uniqid('g_', true),
            'model' => $model,
            'text' => $text,
            'createdAt' => date('c')
        ]);
        exit;
    }
}

http_response_code(404);
echo json_encode(['error' => 'Endpoint not found']);
