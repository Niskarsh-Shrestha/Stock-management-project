<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require 'db.php';
include 'auth_check.php';

if ($user_role !== 'admin' && $user_role !== 'manager') {
    echo json_encode(['success' => false, 'message' => 'Unauthorized']);
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

if (
    empty($productName) || empty($quantity) || empty($availability) ||
    empty($category) || empty($warehouseLocation) || empty($supplierName) || empty($modifiedBy)
) {
    echo json_encode(["error" => "Missing required fields"]);
    exit;
}

$dateAdded = date("Y-m-d H:i:s");
$lastUpdated = $dateAdded;

$stmt = $conn->prepare("INSERT INTO products (productName, quantity, availability, category, warehouseLocation, supplierName, lastUpdated, modifiedBy, dateAdded) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");

if (!$stmt) {
    echo json_encode(["error" => "Prepare failed: " . $conn->error]);
    exit;
}

$stmt->bind_param("sisssssss", $productName, $quantity, $availability, $category, $warehouseLocation, $supplierName, $lastUpdated, $modifiedBy, $dateAdded);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Product added successfully"]);
} else {
    echo json_encode(["error" => "Execute failed: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
