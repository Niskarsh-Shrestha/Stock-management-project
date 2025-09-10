<?php
error_reporting(0);
ini_set('display_errors', 0);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require_once __DIR__ . '/db.php';

if (session_status() !== PHP_SESSION_ACTIVE) {
  session_start();
}

include 'auth_check.php';

if ($user_role !== 'admin' && $user_role !== 'manager') {
    echo json_encode(['success' => false, 'message' => 'Unauthorized']);
    exit;
}

$id = $_POST['CategoryID'];
$name = $_POST['categoryName'];

$query = "UPDATE categories SET CategoryName=? WHERE CategoryID=?";
$stmt = $conn->prepare($query);
$stmt->bind_param("si", $name, $id);

if ($stmt->execute()) {
    echo "Category updated successfully";
} else {
    echo "Failed to update category";
}

