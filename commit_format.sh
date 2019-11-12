if [ -z "$1" ]
then
   echo "No commit name supplied"
else 
   flutter format ./lib
   git add .
   git commit -m "$1"
   git push
fi
