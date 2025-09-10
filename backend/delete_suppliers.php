<?php
error_reporting(0);
ini_set('display_errors', 0);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
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

$payload = json_decode(file_get_contents("php://input"), true) ?: [];
$id = $_POST['id'] ?? $payload['id'] ?? null;

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['SupplierID'])) {
    $supplierID = $_POST['SupplierID'];

    $stmt = $conn->prepare("DELETE FROM suppliers WHERE supplierID = ?");
    $stmt->bind_param("i", $supplierID);

    if ($stmt->execute()) {
        echo json_encode(["success" => true]);
    } else {
        echo json_encode(["success" => false, "message" => $stmt->error]);
    }
} else {
    echo json_encode(["success" => false, "message" => "SupplierID is missing."]);
}

