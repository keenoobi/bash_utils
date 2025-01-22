#!/bin/bash
function CreateDirsAndFiles() {
    echo "Введи номер последнего упражнения в этом дне"
    read num
    for i in $(seq -f "%02g" 0 $num); do
        folder="ex$i"
        if [ -d $folder ]; then
        echo "$folder уже есть" >&2
        else
        mkdir $folder
        fi
        if [ -f $folder/$ptype${daynum}_ex$i.sql ]; then
            echo "$folder/$ptype${daynum}_ex$i.sql уже существует" >&2
        else
            touch $folder/$ptype${daynum}_ex$i.sql
        fi
    done
    echo "Всё создалось, проверь :)"
}

if [ -d ../src ]; then
    echo "Введи какой SQL-проект делаешь team или solo"
    read ptype
    if [[ $ptype = 'team' ]]; then
        ptype='team'
    elif [[ $ptype = 'solo' ]]; then
        ptype='day'
    else
        echo "Неправильный формат проекта, нужно ввести именно team или solo" >&2
        exit 1
    fi
    echo "Введи номер дня"
    read daynum
    if [[ $daynum =~ ^[0-9]$ ]]; then
        daynum="0$daynum"
        CreateDirsAndFiles
    elif [[ $daynum =~ ^0[0-9]$ ]]; then
        CreateDirsAndFiles
    else
        echo "Неверный формат числа" >&2
        exit 1
    fi
    echo "sql.sh" >> ../.gitignore
else
    echo "Скинь меня в папку src твоего SQL проекта" >&2
fi
