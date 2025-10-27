#!/usr/bin/env python3
"""
生成nomogram应用的PNG图标文件
基于SVG文件生成多种尺寸的PNG图标
"""

from PIL import Image, ImageDraw
import os

def create_icon(size):
    """创建指定尺寸的图标"""
    # 创建新图像
    img = Image.new('RGBA', (size, size), (255, 255, 255, 0))
    draw = ImageDraw.Draw(img)

    # 计算各元素尺寸
    border = 0
    circle_radius = int(size * 0.4)  # 76/192 ≈ 0.4
    cross_width = int(size * 0.11)   # 22/192 ≈ 0.11
    cross_length = int(size * 0.58)  # 112/192 ≈ 0.58

    center = size // 2

    # 绘制背景蓝色矩形
    draw.rectangle([border, border, size-border, size-border], fill=(33, 150, 243, 255))

    # 绘制白色圆形
    circle_left = center - circle_radius
    circle_right = center + circle_radius
    circle_top = center - circle_radius
    circle_bottom = center + circle_radius
    draw.ellipse([circle_left, circle_top, circle_right, circle_bottom], fill=(255, 255, 255, 255))

    # 绘制垂直十字线
    v_cross_left = center - cross_width // 2
    v_cross_right = center + cross_width // 2
    v_cross_top = center - cross_length // 2
    v_cross_bottom = center + cross_length // 2
    draw.rectangle([v_cross_left, v_cross_top, v_cross_right, v_cross_bottom], fill=(33, 150, 243, 255))

    # 绘制水平十字线
    h_cross_left = center - cross_length // 2
    h_cross_right = center + cross_length // 2
    h_cross_top = center - cross_width // 2
    h_cross_bottom = center + cross_width // 2
    draw.rectangle([h_cross_left, h_cross_top, h_cross_right, h_cross_bottom], fill=(33, 150, 243, 255))

    return img

def generate_icons():
    """生成所有需要的图标尺寸"""
    sizes = [192, 512]

    # 确保images目录存在
    os.makedirs('images', exist_ok=True)

    for size in sizes:
        print(f"生成 {size}x{size} 图标...")
        icon = create_icon(size)
        filename = f'images/icon-{size}.png'
        icon.save(filename, 'PNG')
        print(f"已保存: {filename}")

    print("所有图标生成完成！")

if __name__ == "__main__":
    generate_icons()