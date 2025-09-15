<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *"); // Allow requests from any origin
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
require_once 'db.php';

$role = $_GET['role'] ?? 'Employees'; // Pass 'Employees' or 'Managers' or 'All'

$sql = "SELECT * FROM notifications 
WHERE recipient = ? OR recipient = 'All' 
ORDER BY created_at DESC";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $role);
$stmt->execute();
$result = $stmt->get_result();

if (!$result) {
    echo json_encode(['success' => fase, 'message' => 'Database query failed.']);
    exit;
}

$notifications = [];
while ($row = $result->fetch_assoc()) {
    $notifications[] = $row;
}

echo json_encode(['notifications' => $notifications]);
?>