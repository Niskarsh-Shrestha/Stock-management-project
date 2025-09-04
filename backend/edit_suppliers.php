<?php
header("Content-Type: application/json");
include 'db.php';
include 'auth_check.php';

if ($user_role !== 'admin' && $user_role !== 'manager') {
    echo json_encode(['success' => false, 'message' => 'Unauthorized']);
    exit;
}

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// Include database connection
require 'db.php';

// Get data from POST request
$supplierID = $_POST['SupplierID'] ?? '';
$supplierName = $_POST['supplierName'] ?? '';
$categoryID = $_POST['categoryID'] ?? '';
$contact = $_POST['contact'] ?? '';
$email = $_POST['email'] ?? '';
$lastOrderDate = $_POST['lastOrderDate'] ?? '';

// Validate required fields
if (empty($supplierID) || empty($supplierName) || empty($categoryID)) {
    echo json_encode(["success" => false, "message" => "Missing required fields"]);
    exit;
}

// Prepare the update query
$stmt = $conn->prepare("UPDATE suppliers SET supplierName = ?, categoryID = ?, contact = ?, email = ?, lastOrderDate = ? WHERE supplierID = ?");
$stmt->bind_param("sisssi", $supplierName, $categoryID, $contact, $email, $lastOrderDate, $supplierID);

// Execute and respond
if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Supplier updated successfully"]);
} else {
    echo json_encode(["success" => false, "message" => "Failed to update supplier"]);
}

$stmt->close();
$conn->close();
?>
