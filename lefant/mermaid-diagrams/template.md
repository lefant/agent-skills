# Mermaid Diagram Template

Copy and adapt this template for hierarchical diagrams:

```mermaid
graph LR
    ROOT["Root/Project Name"]

    ROOT --> CAT1["Category 1 (N files)"]
    CAT1 --> ITEM1["item1<br/>Description"]
    CAT1 --> ITEM2["item2<br/>Description"]
    CAT1 --> ITEM3["item3<br/>Description"]

    ROOT --> CAT2["Category 2 (M files)"]
    CAT2 --> ITEM4["item4<br/>Description"]
    CAT2 --> ITEM5["item5<br/>Description"]

    ROOT --> CAT3["Category 3 (K files)"]
    CAT3 --> ITEM6["item6<br/>Description"]

    style CAT1 fill:#bbdefb
    style CAT2 fill:#ffe0b2
    style CAT3 fill:#c8e6c9
    style ITEM1 fill:#e3f2fd
    style ITEM2 fill:#e3f2fd
    style ITEM3 fill:#e3f2fd
    style ITEM4 fill:#fff3e0
    style ITEM5 fill:#fff3e0
    style ITEM6 fill:#e8f5e9
```

## Color Palette Reference

| Category Color | Item Color | Use For |
|---------------|------------|---------|
| `#bbdefb` | `#e3f2fd` | Blue - Unit tests, core components |
| `#ffe0b2` | `#fff3e0` | Orange - Integration tests, APIs |
| `#c8e6c9` | `#e8f5e9` | Green - Helpers, utilities |
| `#f8bbd9` | `#fce4ec` | Pink - UI components |
| `#d1c4e9` | `#ede7f6` | Purple - Services, middleware |
| `#b2dfdb` | `#e0f2f1` | Teal - Data layer, models |
