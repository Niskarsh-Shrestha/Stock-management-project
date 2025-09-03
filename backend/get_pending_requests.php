<?php
header("Content-Type: application/json");
include 'db.php';

$sql = "SELECT id, username, email, role, is_verified_email FROM users WHERE is_verified = 0";
$result = $conn->query($sql);

$requests = [];
while ($row = $result->fetch_assoc()) {
    $requests[] = $row;
}

echo json_encode(['requests' => $requests]);
?>