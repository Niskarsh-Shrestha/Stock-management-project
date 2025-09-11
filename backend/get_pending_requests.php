<?php
header("Content-Type: application/json");
require_once __DIR__ . '/db.php';

$result = $conn->query("SELECT * FROM users WHERE is_approved = 0");
$pending = [];
while ($row = $result->fetch_assoc()) {
    $pending[] = $row;
}
echo json_encode(['success' => true, 'pending_requests' => $pending]);
?>