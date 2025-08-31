<?php
header("Content-Type: application/json");
include 'db.php';

$role = $_GET['role'] ?? 'Employees'; // Pass 'Employees' or 'Managers' or 'All'

$sql = "SELECT * FROM notifications WHERE recipient = ? OR recipient = 'All' ORDER BY created_at DESC";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $role);
$stmt->execute();
$result = $stmt->get_result();

$notifications = [];
while ($row = $result->fetch_assoc()) {
    $notifications[] = $row;
}

echo json_encode(['notifications' => $notifications]);
?>