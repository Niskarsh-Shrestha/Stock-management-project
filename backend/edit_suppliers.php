<?php
header("Content-Type: application/json");
require_once __DIR__ . '/db.php';
require_once __DIR__ . '/auth_check.php';

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

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// Get data from POST request
$payload = json_decode(file_get_contents("php://input"), true) ?: [];
$supplierID = $_POST['SupplierID'] ?? $payload['SupplierID'] ?? '';
$supplierName = $_POST['supplierName'] ?? $payload['supplierName'] ?? '';
$categoryID = $_POST['categoryID'] ?? $payload['categoryID'] ?? '';
$contact = $_POST['contact'] ?? $payload['contact'] ?? '';
$email = $_POST['email'] ?? $payload['email'] ?? '';
$lastOrderDate = $_POST['lastOrderDate'] ?? $payload['lastOrderDate'] ?? '';

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
