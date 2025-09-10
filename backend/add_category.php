<?php
error_reporting(0);
ini_set('display_errors', 0);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require_once __DIR__ . '/db.php';

if (session_status() !== PHP_SESSION_ACTIVE) {
  session_start();
}

if (!isset($_SESSION['user_id']) || !isset($_SESSION['user_role'])) {
  echo json_encode(['success' => false, 'message' => 'Unauthorized']);
  exit;
}

// Optionally, check for admin/manager role:
if ($_SESSION['user_role'] !== 'admin' && $_SESSION['user_role'] !== 'manager') {
  echo json_encode(['success' => false, 'message' => 'Insufficient permissions']);
  exit;
}

$name = $_POST['categoryName'];

$query = "INSERT INTO categories (CategoryName, dateAdded) VALUES (?, NOW())";
$stmt = $conn->prepare($query);
$stmt->bind_param("s", $name);

if ($stmt->execute()) {
    echo "Category added successfully";
} else {
    echo "Failed to add category";
}

$payload = json_decode(file_get_contents("php://input"), true) ?: [];
$id = $_POST['id'] ?? $payload['id'] ?? null;
// For add/edit: get other fields similarly

