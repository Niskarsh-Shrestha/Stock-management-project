<?php
error_reporting(0);
ini_set('display_errors', 0);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
include 'db.php';

$id = $_POST['CategoryID'];

$query = "DELETE FROM categories WHERE CategoryID=?";
$stmt = $conn->prepare($query);
$stmt->bind_param("i", $id);

if ($stmt->execute()) {
    echo "Category deleted successfully";
} else {
    echo "Failed to delete category";
}

