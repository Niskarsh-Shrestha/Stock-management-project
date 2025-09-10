<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require 'db.php';
require_once __DIR__ . '/db.php';
require_once __DIR__ . '/auth_check.php';

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

$raw  = file_get_contents('php://input');
$data = json_decode($raw, true);
if (!is_array($data)) $data = $_POST;

$productName       = trim($data['productName'] ?? '');
$quantity          = (int)($data['quantity'] ?? 0);
$availability      = trim($data['availability'] ?? 'Yes');
$category          = trim($data['category'] ?? '');
$warehouseLocation = trim($data['warehouseLocation'] ?? '');
$supplierName      = trim($data['supplierName'] ?? '');
$modifiedBy        = $_SESSION['user_role'];

if ($productName === '' || $quantity <= 0 || $category === '' || $warehouseLocation === '' || $supplierName === '') {
  echo json_encode(['success'=>false,'message'=>'Validation failed']); exit;
}

$sql = "INSERT INTO products (productName, quantity, availability, category, warehouseLocation, supplierName, modifiedBy, dateAdded, lastUpdatedDate)
        VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), NOW())";
$stmt = $conn->prepare($sql);
if (!$stmt) { echo json_encode(['success'=>false,'message'=>$conn->error]); exit; }

$stmt->bind_param('sisssss', $productName, $quantity, $availability, $category, $warehouseLocation, $supplierName, $modifiedBy);

if (!$stmt->execute()) { echo json_encode(['success'=>false,'message'=>$stmt->error]); exit; }
echo json_encode(['success'=>true, 'id'=>$stmt->insert_id]);

$stmt->close();
$conn->close();
?>
