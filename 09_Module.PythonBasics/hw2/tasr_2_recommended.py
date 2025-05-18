# Запросить данные у пользователя и распечатать их.

text = input('Введите текст: ')
print(text)

# Составить форматированную строку

a = 10
b = 15
print(f'Сумма a и b - {a+b}')

# Распечатать содержимое файла

with open('my_file.txt', 'r', encoding='utf-8') as file:
    print(file.read())
    
# Создать функцию, которая принимает два аргумента,
# вернуть сумму двух аргументов

def get_sum(a, b):
    return a+b

print(get_sum(45, 55))

# Создать функцию которая принимает любое количество параметров,
# распечаатать эти параметры.

def get_param(*args):
    print(args)
    
get_param(43, 5, 23, 65, 2, 67)

# Создать функцию, в которой применяется ключевое слово global.

counter = 0 

def increase_counter():
    global counter 
    counter += 1
    print(f"Текущее значение counter: {counter}")

increase_counter() 
increase_counter()  