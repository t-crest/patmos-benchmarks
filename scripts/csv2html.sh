#!/bin/bash

echo "<table>"
while read INPUT
do
  echo "<tr><td>${INPUT//,/</td><td>}</td></tr>"
done
echo "</table>"
