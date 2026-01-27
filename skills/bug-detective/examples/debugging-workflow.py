"""
调试流程示例

这个示例展示了完整的调试流程，从发现问题到解决问题。
"""

import logging

# 配置日志
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)


# ============================================
# 问题 1：IndexError
# ============================================

def get_item(items, index):
    """
    问题：直接访问索引可能导致 IndexError
    
    错误现象：
    IndexError: list index out of range
    """
    # ❌ 有问题的代码
    # return items[index]
    
    # ✅ 修复后的代码
    if 0 <= index < len(items):
        return items[index]
    else:
        logger.warning(f"索引 {index} 超出范围 [0, {len(items)})")
        return None


# ============================================
# 问题 2：TypeError - 字符串拼接
# ============================================

def format_message(name, count):
    """
    问题：尝试拼接字符串和数字
    
    错误现象：
    TypeError: can only concatenate str (not "int") to str
    """
    # ❌ 有问题的代码
    # return name + ": " + count
    
    # ✅ 修复后的代码
    return f"{name}: {count}"
    # 或
    # return name + ": " + str(count)


# ============================================
# 问题 3：KeyError
# ============================================

def get_user_info(users, user_id):
    """
    问题：直接访问字典中可能不存在的键
    
    错误现象：
    KeyError: 'user_123'
    """
    # ❌ 有问题的代码
    # return users[user_id]
    
    # ✅ 修复后的代码 - 方法1：使用 get()
    return users.get(user_id, None)
    
    # ✅ 修复后的代码 - 方法2：检查键是否存在
    # if user_id in users:
    #     return users[user_id]
    # return None


# ============================================
# 问题 4：AttributeError - None 对象
# ============================================

def process_data(data_provider):
    """
    问题：data_provider 可能返回 None
    
    错误现象：
    AttributeError: 'NoneType' object has no attribute 'process'
    """
    data = data_provider.get_data()
    
    # ❌ 有问题的代码
    # return data.process()
    
    # ✅ 修复后的代码
    if data is not None:
        return data.process()
    else:
        logger.error("数据为 None，无法处理")
        return None


# ============================================
# 问题 5：修改正在迭代的列表
# ============================================

def remove_even_numbers(numbers):
    """
    问题：迭代时修改列表导致跳过元素
    
    错误现象：
    某些偶数没有被移除
    """
    # ❌ 有问题的代码
    # for num in numbers:
    #     if num % 2 == 0:
    #         numbers.remove(num)
    # return numbers
    
    # ✅ 修复后的代码 - 方法1：列表推导式
    return [num for num in numbers if num % 2 != 0]
    
    # ✅ 修复后的代码 - 方法2：使用副本
    # for num in numbers[:]:
    #     if num % 2 == 0:
    #         numbers.remove(num)
    # return numbers


# ============================================
# 调试技巧示例
# ============================================

def debug_with_logging(data):
    """
    使用日志追踪问题
    """
    logger.debug(f"输入数据: {data}")
    
    # 步骤 1
    processed = step1(data)
    logger.debug(f"步骤1结果: {processed}")
    
    # 步骤 2
    result = step2(processed)
    logger.debug(f"步骤2结果: {result}")
    
    return result


def step1(data):
    """模拟步骤1"""
    return [x * 2 for x in data]


def step2(data):
    """模拟步骤2"""
    return sum(data)


# ============================================
# 异常处理示例
# ============================================

def safe_divide(a, b):
    """
    正确的异常处理模式
    """
    try:
        result = a / b
        logger.info(f"{a} / {b} = {result}")
        return result
    except ZeroDivisionError:
        logger.error(f"除数不能为零: {b}")
        return None
    except TypeError as e:
        logger.error(f"类型错误: {e}")
        return None


# ============================================
# 使用断言进行调试
# ============================================

def calculate_discount(price, discount_rate):
    """
    使用断言验证假设
    """
    # 断言：价格应该是正数
    assert price > 0, f"价格应该是正数，实际: {price}"
    
    # 断言：折扣率应该在 0-1 之间
    assert 0 <= discount_rate <= 1, f"折扣率应该在 0-1 之间，实际: {discount_rate}"
    
    discounted_price = price * (1 - discount_rate)
    
    # 断言：折扣后的价格应该小于原价
    assert discounted_price <= price, "折扣价格应该小于原价"
    
    return discounted_price


# ============================================
# 测试代码
# ============================================

if __name__ == "__main__":
    print("=" * 50)
    print("调试示例")
    print("=" * 50)
    
    # 测试 get_item
    print("\n1. 测试 get_item:")
    items = ['a', 'b', 'c']
    print(f"get_item(items, 1) = {get_item(items, 1)}")
    print(f"get_item(items, 10) = {get_item(items, 10)}")
    
    # 测试 format_message
    print("\n2. 测试 format_message:")
    print(f"format_message('Count', 42) = {format_message('Count', 42)}")
    
    # 测试 get_user_info
    print("\n3. 测试 get_user_info:")
    users = {'user_1': 'Alice', 'user_2': 'Bob'}
    print(f"get_user_info(users, 'user_1') = {get_user_info(users, 'user_1')}")
    print(f"get_user_info(users, 'user_999') = {get_user_info(users, 'user_999')}")
    
    # 测试 remove_even_numbers
    print("\n4. 测试 remove_even_numbers:")
    numbers = [1, 2, 3, 4, 5, 6]
    print(f"原始: {numbers}")
    print(f"结果: {remove_even_numbers(numbers)}")
    
    # 测试 safe_divide
    print("\n5. 测试 safe_divide:")
    print(f"safe_divide(10, 2) = {safe_divide(10, 2)}")
    print(f"safe_divide(10, 0) = {safe_divide(10, 0)}")
    
    # 测试 calculate_discount
    print("\n6. 测试 calculate_discount:")
    print(f"calculate_discount(100, 0.2) = {calculate_discount(100, 0.2)}")
