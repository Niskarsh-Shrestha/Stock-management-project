<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require 'db.php';
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


// Fetch POST data safely
$productName = $_POST['productName'] ?? '';
$quantity = $_POST['quantity'] ?? '';
$availability = $_POST['availability'] ?? '';
$category = $_POST['category'] ?? '';
$warehouseLocation = $_POST['warehouseLocation'] ?? '';
$supplierName = $_POST['supplierName'] ?? '';
$modifiedBy = $_POST['modifiedBy'] ?? '';

$payload = json_decode(file_get_contents("php://input"), true) ?: [];
$id = $_POST['id'] ?? $payload['id'] ?? null;

if (
    empty($productName) || empty($quantity) || empty($availability) ||
    empty($category) || empty($warehouseLocation) || empty($supplierName) || empty($modifiedBy)
) {
    echo json_encode(["error" => "Missing required fields"]);
    exit;
}

$dateAdded = date("Y-m-d H:i:s");
$lastUpdated = $dateAdded;

$stmt = $conn->prepare("INSERT INTO products (productName, quantity, availability, category, 
warehouseLocation, supplierName, lastUpdated, modifiedBy, dateAdded) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");

if (!$stmt) {
    echo json_encode(["error" => "Prepare failed: " . $conn->error]);
    exit;
}

$stmt->bind_param("sisssssss", $productName, $quantity, $availability, $category, 
$warehouseLocation, $supplierName, $lastUpdated, $modifiedBy, $dateAdded);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Product added successfully"]);
} else {
    echo json_encode(["error" => "Execute failed: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
