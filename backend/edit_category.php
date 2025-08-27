<?php
error_reporting(0);
ini_set('display_errors', 0);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
include 'db.php';

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

