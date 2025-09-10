<?php
header("Content-Type: application/json");
require_once __DIR__ . '/db.php';

if (session_status() !== PHP_SESSION_ACTIVE) {
  session_start();
}

include 'auth_check.php';

$data = json_decode(file_get_contents("php://input"));
$id = intval($data->id ?? 0);

if ($user_role !== 'admin' && $user_role !== 'manager') {
    echo json_encode(['success' => false, 'message' => 'Unauthorized']);
    exit;
}

if ($id) {
    $stmt = $conn->prepare("DELETE FROM users WHERE id=?");
    $stmt->bind_param("i", $id);
    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "User deleted."]);
    } else {
        echo json_encode(["success" => false, "message" => "Delete failed."]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Invalid user ID."]);
}
?>