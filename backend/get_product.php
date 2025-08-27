<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require 'db.php';

$query = "SELECT 
  p.id, 
  p.productName, 
  p.quantity, 
  p.availability, 
  p.warehouseLocation,
  p.dateAdded,
  p.lastUpdated,
  p.modifiedBy,
  p.category,
  p.supplierName
FROM products p
ORDER BY p.dateAdded DESC";

$result = mysqli_query($conn, $query);
$products = [];

if ($result) {
    while ($row = mysqli_fetch_assoc($result)) {
        $products[] = $row;
    }
    echo json_encode(['products' => $products]);
} else {
    echo json_encode(['error' => mysqli_error($conn)]);
}
?>
