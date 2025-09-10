<?php
require_once __DIR__ . '/db.php';
header('Content-Type: application/json');

$hdrSid = $_SERVER['HTTP_X_SESSION_ID'] ?? null;
if ($hdrSid) {
  if (session_status() === PHP_SESSION_ACTIVE) { session_write_close(); }
  session_id($hdrSid);
}
if (session_status() !== PHP_SESSION_ACTIVE) { session_start(); }

if (empty($_SESSION['user_id']) || empty($_SESSION['user_role'])) {
  echo json_encode(['success' => false, 'message' => 'Unauthorized']);
  exit;
}

$user_id   = (int)$_SESSION['user_id'];
$user_role = strtolower((string)$_SESSION['user_role']);