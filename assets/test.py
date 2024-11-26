import json
import numpy as np
from shapely.geometry import shape, mapping
import pycountry
from difflib import get_close_matches

def get_country_code(country_name):
    special_cases = {
        "United States of America": "US",
        "South Korea": "KR",
        "North Korea": "KP",
        "United Kingdom": "GB",
        "Russian Federation": "RU",
        "Taiwan": "TW",
        "Vietnam": "VN",
        "Laos": "LA",
        "Fr. S. Antarctic Lands": "TF",
        "Bosnia and Herz.": "BA",
        "Bolivia": "BO",
        "Dem. Rep. Congo": "CD",
        "Czech Rep.": "CZ",
        "Falkland Is.": "FK",
        "Kosovo": "XK",
        "Lao PDR": "LA",
        "Moldova": "MD",
        "Dem. Rep. Korea": "KP",
        "Tanzania": "TZ",
        "Venezuela": "VE"
    }
    
    if country_name in special_cases:
        return special_cases[country_name]
    
    try:
        country = pycountry.countries.get(name=country_name)
        if country:
            return country.alpha_2
    except:
        pass
    
    return country_name

def calculate_centroid(geometry):
    # Shapely 객체로 변환
    geom = shape(geometry)
    # 중심점 계산
    centroid = geom.centroid
    return [centroid.x, centroid.y]

# GeoJSON 파일 읽기
with open('world_map.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# 결과를 저장할 리스트
country_coordinates = []

# 각 국가의 정보 처리
for feature in data['features']:
    country_name = feature['properties']['name']
    iso_code = get_country_code(country_name)
    
    try:
        # 중심점 계산
        coordinates = calculate_centroid(feature['geometry'])
        
        # 국가 정보 저장
        country_info = {
            "country_code": iso_code,
            "country_name": feature['properties']['admin'],
            "coordinates": {
                "longitude": round(coordinates[0], 6),
                "latitude": round(coordinates[1], 6)
            }
        }
        country_coordinates.append(country_info)
        
    except Exception as e:
        print(f"Error processing {country_name}: {str(e)}")

# 결과를 JSON 파일로 저장
output = {
    "countries": country_coordinates
}

with open('country_coordinates.json', 'w', encoding='utf-8') as f:
    json.dump(output, f, ensure_ascii=False, indent=2)

print("처리 완료! country_coordinates.json 파일이 생성되었습니다.")