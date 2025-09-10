<?php
header("Content-Type: application/json");
require_once __DIR__ . '/db.php';

if (session_status() !== PHP_SESSION_ACTIVE) {
  session_start();
}

$data = json_decode(file_get_contents("php://input"));
$recipient = $data->recipient ?? '';
$message = trim($data->message ?? '');

if ($message === '') {
    echo json_encode(['success' => false, 'message' => 'Message cannot be empty']);
    exit;
}

$stmt = $conn->prepare("INSERT INTO notifications (recipient, message) VALUES (?, ?)");
$stmt->bind_param("ss", $recipient, $message);
$stmt->execute();

echo json_encode(['success' => true, 'message' => 'Notification sent']);
?>