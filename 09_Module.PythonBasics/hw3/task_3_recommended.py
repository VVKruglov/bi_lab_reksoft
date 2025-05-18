# Создать класс в конструктор которого передается одно число
# В этом классе дожен быть метод show, который распечатывает
# переданное число.

class Show_number:
    def __init__(self, num):
        self.num = num
    
    def show(self):
        print(self.num)
        

four = Show_number(4)
four.show()

# Создать класс, который наследуется от предыдущего класса и в этот
# класс передается два числа.
# Данный класс реализует метод calc, который складывает эти два числа.

class Calc_two_number(Show_number):
    def __init__(self, num_1, num_2):
        self.num_1 = num_1
        self.num_2 = num_2 
        super().__init__(self)
        
    def calc(self):
        return self.num_1 + self.num_2
    
    def show(self):
        print(self.num_1, self.num_2)

calc_1 = Calc_two_number(43, 98)
print(calc_1.calc())

# Создать блок try/except/finally

def divide(x, y):
    try:
        return x/y
    except:
        raise ZeroDivisionError
    finally:
        print(';)')
        
print(divide(7, 0))