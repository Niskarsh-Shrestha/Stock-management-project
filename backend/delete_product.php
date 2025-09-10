<?php
error_reporting(0);
ini_set('display_errors', 0);

require_once __DIR__ . '/db.php'; // Handles CORS and DB connection

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
    // Support both form-data and JSON
    $payload = json_decode(file_get_contents("php://input"), true) ?: [];
    $id = $_POST['id'] ?? $payload['id'] ?? null;

    if (!$id) {
        echo json_encode(["success" => false, "message" => "Product ID required"]);
        exit;
    }

    $stmt = $conn->prepare("DELETE FROM products WHERE id=?");
    $stmt->bind_param("i", $id);
    if ($stmt->execute()) {
        echo json_encode(["success" => true]);
    } else {
        echo json_encode(["success" => false, "error" => $stmt->error]);
    }
    $stmt->close();
}
?>
