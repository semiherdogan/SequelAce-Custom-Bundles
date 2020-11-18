#!/usr/bin/env php
<?php
$stdIn = fopen("php://stdin", "r");
$result = [];
while($row = fgetcsv($stdIn, 0)) {
    array_push($result, $row);
}

$columns = array_shift($result);

if ($result) {
    foreach($result as &$data) {
        foreach ($data as &$d) {
            if (in_array($d, ['NULL', 'null'])) {
                $d = null;
            }

            if (is_numeric($d)) {
                if (strpos($d, ',') !== false || strpos($d, '.') !== false) {
                    $d = (float) $d;
                } else {
                    $d = (int) $d;
                }
            }
        }

        $data = array_combine($columns, $data);
    }
}

$result = json_encode($result, JSON_PRETTY_PRINT);

$cmd = 'echo '.escapeshellarg($result).' | __CF_USER_TEXT_ENCODING='.posix_getuid().':0x8000100:0x8000100 pbcopy';
shell_exec($cmd);
