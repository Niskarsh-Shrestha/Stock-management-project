<?php
require_once __DIR__ . '/db.php'; // sets CORS + cookie flags

if (session_status() !== PHP_SESSION_ACTIVE) {
  session_start();
}

if (!isset($_SESSION['user_id']) || !isset($_SESSION['user_role'])) {
  echo json_encode(['success' => false, 'message' => 'Unauthorized']);
  exit;
}

$user_id   = (int)$_SESSION['user_id'];
$user_role = strtolower((string)$_SESSION['user_role']); // 'admin'|'manager'|'employee'