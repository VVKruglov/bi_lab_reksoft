# Создать функцию, которая принимает два числа и делит одно на другое.
# в случае деления на 0, перехватить исключение и вернуть None.

def divide(x, y):
    try:
        return x/y
    except:
        print('Erorr! Division by zero')
        return None
    finally:
        print(';)')
        
print(divide(7, 0))

# Создать класс менеджера контекста, который будет при входе в блок
# печатать текст переданный в конструкторе. А при выходе из блока
# печатать "context closed".

class The_context_manager:
    def __init__(self, text):
        self.text = text
    
    def __enter__(self):
        print(self.text)
        return self  
    
    def __exit__(self, exc_type, exc_value, traceback):
        print("Context closed")
        
with The_context_manager("Вход в контекст"):
    print("Внутри контекста")
        
        
# Создать иерархию классов
#            Здание
#           /       \
# жилой дом        магазин

# классы должны иметь 3 общих атрибута:
# - адрес
# - количество этажей
# - материал стен

# для жилого дома добавить атрибут : количество жильцов
# для магазина: тип - количество работников

# Общие атрибуты должны быть расположены в базовом классе.

# Реализовать методы: распечатки адреса и возвращения количества этажей в здании.
# Необходимо создать по одному экземпляру жилого дома и магазина распечатать их адреса.
# Реализовать метод __lt__ для сравнения объектов через оператор меньше: ob1 < obj2
# Сравнение объектов производить по количеству этажей.
# Т.е. объект считается меньше, если в нем меньше этажей, чем в другом объекте.


class Building:  
    
    def __init__(self, address, number_of_floors, wall_material):
        self.address = address
        self.number_of_floors = number_of_floors
        self.wall_material = wall_material
        
    def show_address(self): 
        print(self.address)
        
    def get_number_of_floors(self):
        return self.number_of_floors
    
    def __lt__(self, other):
        return self.number_of_floors < other.number_of_floors


class House(Building):
     
    def __init__(self, address, number_of_floors, wall_material, number_of_tenants):
        super().__init__(address, number_of_floors, wall_material)
        self.number_of_tenants = number_of_tenants 


class Shop(Building):
    
    def __init__(self, address, number_of_floors, wall_material, type_shop, number_employees):
        super().__init__(address, number_of_floors, wall_material)
        self.type_shop = type_shop
        self.number_employees = number_employees


green_house = House('Green street, 23', 2, 'masonry', 500)
tech_shop = Shop('Oak street, 253', 3, 'masonry', 'technic', 10)

green_house.show_address()
tech_shop.show_address()

print(green_house > tech_shop)