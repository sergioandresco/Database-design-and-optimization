# Ecommify Sharding Strategy

Atlas M0 no permite sharding real. Se documenta y simula.

## Shard key propuesta

```javascript
{ "category.name_en": 1, "_id": "hashed" }
```

HHI calculado por categoría: 0.0495.
