# Создать словарь из трех пар ключ-значение

dic = {'cat':'кошка', 'dog':'собака', 'cow':'корова'}
print(dic['cat'])

for key in dic:
    print(key)

for value in dic.values():
    print(value)
    
for key, value in dic.items():
    print(f'{key} - {value}')
    

#  С помощью list-comprehensions создать список целых чисел от 11 до 19

lst = [i for i in range(11, 19)]
print(lst)

# Создать два множества. Найти общие элементы этих двух множеств

set_1 = {4, 5, 8, 34, 53, 64}
set_2 = {64, 93, -23, 5, 8}
set_3 = set_1 & set_2
print(sorted(set_3))

# создать строку 'TEST', если в ней есть буква 'E', напечатать 'pass', иначе напечатать 'fail'

string = 'TEST'
if 'E' in 'TEST':
    print('pass')
else:
    print('fail')
    
# с помощью вложенного цикла for распечатать таблицу умножения от 1 до 5

for i in range(1, 6):
    for j in range(1, 6):
        print(f'{i*j:3}', end=' ')
    print()
