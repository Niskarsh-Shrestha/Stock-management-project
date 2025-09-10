<?php
error_reporting(0);
ini_set('display_errors', 0);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require 'db.php';
include 'auth_check.php';

require_once __DIR__ . '/db.php';
if (session_status() !== PHP_SESSION_ACTIVE) session_start();

if (!isset($_SESSION['user_id']) || !isset($_SESSION['user_role'])) {
  echo json_encode(['success' => false, 'message' => 'Unauthorized']);
  exit;
}

// Optionally, check for admin/manager role:
if ($_SESSION['user_role'] !== 'admin' && $_SESSION['user_role'] !== 'manager') {
  echo json_encode(['success' => false, 'message' => 'Insufficient permissions']);
  exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $stmt = $conn->prepare("DELETE FROM products WHERE id=?");
    $stmt->bind_param("i", $_POST['id']);  // <--- **uses 'id' as key here**
    if ($stmt->execute()) {
        echo json_encode(["success" => true]);
    } else {
        echo json_encode(["error" => $stmt->error]);
    }
    $stmt->close();
}
require_once __DIR__ . '/db.php';

if (session_status() !== PHP_SESSION_ACTIVE) {
  session_start();
}
?>
