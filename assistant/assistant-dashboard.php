<?php
require_once __DIR__ . '/../api/helpers.php';
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0, private');
header('Pragma: no-cache');
header('Expires: 0');

requireAuth();
$role = currentRole();
if ($role !== 'assistant') {
	if ($role === 'admin') {
		header('Location: ' . appendTabSession('../admin/index.php'));
	} elseif ($role === 'supervisor') {
		header('Location: ' . appendTabSession('../supervisor/supervisor-dashboard.php'));
	} elseif (($_SESSION['user_type'] ?? '') === 'general') {
		header('Location: ' . appendTabSession('../user-dashboard.php'));
	} else {
		header('Location: ' . appendTabSession('../index.html'));
	}
	exit;
}

header('Content-Type: text/html; charset=utf-8');
readfile(__DIR__ . '/assistant-dashboard.html');
