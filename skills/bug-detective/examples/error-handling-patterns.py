"""
错误处理模式示例

展示各种错误处理的最佳实践
"""

import logging
from typing import Optional, List, Dict, Any
from functools import wraps

logger = logging.getLogger(__name__)


# ============================================
# 模式 1：具体异常捕获
# ============================================

def read_file(filepath: str) -> Optional[str]:
    """
    捕获具体异常而不是宽泛的 Exception
    """
    try:
        with open(filepath, 'r') as f:
            return f.read()
    except FileNotFoundError:
        logger.error(f"文件不存在: {filepath}")
        return None
    except PermissionError:
        logger.error(f"没有权限读取文件: {filepath}")
        return None
    except UnicodeDecodeError:
        logger.error(f"文件编码错误: {filepath}")
        return None


# ============================================
# 模式 2：带重试的操作
# ============================================

def retry_operation(max_attempts: int = 3):
    """
    装饰器：自动重试失败的操作
    """
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(1, max_attempts + 1):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    if attempt == max_attempts:
                        logger.error(f"操作失败，已重试 {max_attempts} 次: {e}")
                        raise
                    logger.warning(f"操作失败，第 {attempt} 次重试...")
            return None
        return wrapper
    return decorator


@retry_operation(max_attempts=3)
def unstable_api_call() -> Dict[str, Any]:
    """
    模拟不稳定的 API 调用
    """
    import random
    if random.random() < 0.7:  # 70% 失败率
        raise ConnectionError("API 连接失败")
    return {"status": "success", "data": "result"}


# ============================================
# 模式 3：上下文管理器处理资源
# ============================================

class DatabaseConnection:
    """
    自定义上下文管理器，确保资源正确释放
    """
    def __init__(self, connection_string: str):
        self.connection_string = connection_string
        self.connection = None
    
    def __enter__(self):
        logger.info(f"连接数据库: {self.connection_string}")
        self.connection = f"Connection to {self.connection_string}"
        return self.connection
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        if exc_type is not None:
            logger.error(f"发生异常: {exc_val}")
        logger.info("关闭数据库连接")
        # 清理资源
        self.connection = None
        return False  # 不抑制异常


# ============================================
# 模式 4：链式异常（保留原始异常）
# ============================================

def validate_and_process(data: Dict[str, Any]) -> Any:
    """
    使用 raise from 保留原始异常链
    """
    try:
        # 验证数据
        if 'value' not in data:
            raise ValueError("数据中缺少 'value' 字段")
        
        value = data['value']
        if not isinstance(value, (int, float)):
            raise TypeError(f"value 应该是数字，实际类型: {type(value)}")
        
        # 处理数据
        return value * 2
        
    except (ValueError, TypeError) as e:
        # 保留原始异常并添加上下文
        raise RuntimeError(f"数据处理失败: {data}") from e


# ============================================
# 模式 5：结果对象模式（不使用异常）
# ============================================

class Result:
    """
    结果对象模式：封装成功/失败状态
    """
    def __init__(self, success: bool, value: Any = None, error: str = None):
        self.success = success
        self.value = value
        self.error = error
    
    @classmethod
    def ok(cls, value: Any) -> 'Result':
        return cls(success=True, value=value)
    
    @classmethod
    def err(cls, error: str) -> 'Result':
        return cls(success=False, error=error)
    
    def is_ok(self) -> bool:
        return self.success
    
    def is_err(self) -> bool:
        return not self.success
    
    def unwrap(self) -> Any:
        if not self.success:
            raise ValueError(f"尝试解包错误结果: {self.error}")
        return self.value
    
    def unwrap_or(self, default: Any) -> Any:
        return self.value if self.success else default


def safe_divide_result(a: float, b: float) -> Result:
    """
    使用结果对象而不是异常
    """
    if b == 0:
        return Result.err(f"除数不能为零: {b}")
    
    try:
        return Result.ok(a / b)
    except Exception as e:
        return Result.err(f"计算失败: {e}")


# ============================================
# 模式 6：多项验证错误收集
# ============================================

class ValidationError(Exception):
    """自定义验证错误"""
    def __init__(self, errors: List[str]):
        self.errors = errors
        super().__init__("\n".join(errors))


def validate_user(data: Dict[str, Any]) -> None:
    """
    收集所有验证错误而不是遇到第一个就停止
    """
    errors = []
    
    if 'name' not in data:
        errors.append("缺少 'name' 字段")
    elif not isinstance(data['name'], str):
        errors.append("'name' 应该是字符串")
    elif len(data['name']) < 2:
        errors.append("'name' 长度应该至少为 2")
    
    if 'age' not in data:
        errors.append("缺少 'age' 字段")
    elif not isinstance(data['age'], int):
        errors.append("'age' 应该是整数")
    elif data['age'] < 0 or data['age'] > 150:
        errors.append("'age' 应该在 0-150 之间")
    
    if 'email' in data and '@' not in data['email']:
        errors.append("'email' 格式不正确")
    
    if errors:
        raise ValidationError(errors)


# ============================================
# 模式 7：默认值和回退
# ============================================

def get_config(config: Dict[str, Any], key: str, default: Any = None) -> Any:
    """
    安全获取配置，支持多级键和默认值
    """
    if '.' in key:
        # 支持嵌套键，如 "database.host"
        keys = key.split('.')
        value = config
        for k in keys:
            if isinstance(value, dict) and k in value:
                value = value[k]
            else:
                return default
        return value
    
    # 简单键
    return config.get(key, default)


# ============================================
# 模式 8：优雅降级
# ============================================

def get_user_preferences(user_id: int) -> Dict[str, Any]:
    """
    尝试多种方法获取用户偏好，优雅降级
    """
    # 尝试 1：从缓存获取
    try:
        return _get_from_cache(user_id)
    except Exception as e:
        logger.warning(f"从缓存获取失败: {e}")
    
    # 尝试 2：从数据库获取
    try:
        return _get_from_database(user_id)
    except Exception as e:
        logger.warning(f"从数据库获取失败: {e}")
    
    # 尝试 3：使用默认配置
    logger.info("使用默认配置")
    return _get_default_preferences()


def _get_from_cache(user_id: int) -> Dict[str, Any]:
    # 模拟缓存失败
    raise ConnectionError("缓存连接失败")


def _get_from_database(user_id: int) -> Dict[str, Any]:
    # 模拟数据库失败
    raise ConnectionError("数据库连接失败")


def _get_default_preferences() -> Dict[str, Any]:
    return {
        "theme": "light",
        "language": "zh-CN",
        "notifications": True
    }


# ============================================
# 测试代码
# ============================================

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    
    print("=" * 50)
    print("错误处理模式示例")
    print("=" * 50)
    
    # 测试结果对象模式
    print("\n1. 结果对象模式:")
    result1 = safe_divide_result(10, 2)
    print(f"10 / 2 = {result1.unwrap()}")
    
    result2 = safe_divide_result(10, 0)
    print(f"10 / 0 = {result2.unwrap_or('N/A')} ({result2.error})")
    
    # 测试优雅降级
    print("\n2. 优雅降级:")
    prefs = get_user_preferences(123)
    print(f"用户偏好: {prefs}")
    
    # 测试上下文管理器
    print("\n3. 上下文管理器:")
    try:
        with DatabaseConnection("localhost:5432") as conn:
            print(f"连接: {conn}")
    except Exception as e:
        print(f"操作失败: {e}")
