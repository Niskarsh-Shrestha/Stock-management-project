<?php
error_reporting(0);
ini_set('display_errors', 0);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require 'db.php';
require_once __DIR__ . '/auth_check.php';

if (!in_array($user_role, ['admin','manager'], true)) {
  echo json_encode(['success'=>false,'message'=>'Unauthorized']); exit;
}

$raw  = file_get_contents('php://input');
$data = json_decode($raw, true);
if (!is_array($data)) $data = $_POST;

$id                = (int)($data['id'] ?? 0);
$productName       = trim($data['productName'] ?? '');
$quantity          = (int)($data['quantity'] ?? 0);
$availability      = trim($data['availability'] ?? 'Yes');
$category          = trim($data['category'] ?? '');
$warehouseLocation = trim($data['warehouseLocation'] ?? '');
$supplierName      = trim($data['supplierName'] ?? '');
$modifiedBy        = $user_role;

if ($id <= 0) { echo json_encode(['success'=>false,'message'=>'Invalid id']); exit; }

$sql = "UPDATE products
        SET productName=?, quantity=?, availability=?, category=?, warehouseLocation=?, supplierName=?, modifiedBy=?, lastUpdatedDate=NOW()
        WHERE id=?";
$stmt = $conn->prepare($sql);
if (!$stmt) { echo json_encode(['success'=>false,'message'=>$conn->error]); exit; }

$stmt->bind_param('sisssssi', $productName, $quantity, $availability, $category, $warehouseLocation, $supplierName, $modifiedBy, $id);

if (!$stmt->execute()) { echo json_encode(['success'=>false,'message'=>$stmt->error]); exit; }
echo json_encode(['success'=>true]);
?>
