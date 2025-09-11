<?php
require 'db.php';

$user_id = intval($_POST['user_id'] ?? 0);

$sql = "UPDATE users SET is_approved = 1 WHERE id = $user_id";
if ($conn->query($sql)) {
    echo json_encode(['success' => true]);
} else {
    echo json_encode(['success' => false, 'message' => 'Approval failed.']);
}
?>