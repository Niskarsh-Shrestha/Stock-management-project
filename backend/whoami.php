<?php
require_once __DIR__ . '/auth_check.php';
echo json_encode([
  'success'   => true,
  'user_id'   => $user_id,
  'user_role' => $user_role,
  'sid'       => session_id(),
]);