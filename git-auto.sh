#!/data/data/com.termux/files/usr/bin/bash

echo "📝 Escribe un mensaje para el commit:"
read mensaje

git add .
git commit -m "deluxe"
git push origin main

echo "✅ Cambios subidos a GitHub correctamente."
