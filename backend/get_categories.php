<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

require 'db.php';

$query = "SELECT 
    categoryID AS CategoryID, 
    categoryName AS CategoryName, 
    dateAdded AS dateAdded 
FROM categories 
ORDER BY dateAdded DESC";

$result = mysqli_query($conn, $query);

$categories = [];

if ($result) {
    while ($row = mysqli_fetch_assoc($result)) {
        $categories[] = $row;
    }
    echo json_encode(['categories' => $categories]);
} else {
    echo json_encode(['error' => mysqli_error($conn)]);
}
?>
