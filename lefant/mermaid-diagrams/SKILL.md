---
name: mermaid-diagrams
description: Best practices for creating clear, well-structured Mermaid diagrams to visualize hierarchies, file structures, and component relationships.
---

# Mermaid Diagrams Skill

Use this skill when creating hierarchical Mermaid diagrams. This skill captures best practices for visualization, particularly for file structures, test suites, and other tree-like data.

## Purpose

Create clear, well-structured Mermaid diagrams that effectively visualize hierarchical data. This skill provides patterns for parallel structures, color coding, and three-level hierarchies.

## When to Use

Create a Mermaid diagram when:
- Visualizing file structures or test suites
- Showing hierarchical relationships (categories -> items)
- Creating architectural overviews
- Documenting component relationships

## Directory Layout

Diagrams are stored in `./docs/diagrams/` at the project root if that directory exists. Otherwise, embed diagrams directly in relevant documentation files.

## Key Principles

### 1. Choose the Right Graph Direction

- **`graph LR`** - Left to Right (horizontal) - **Best for listing many items**
- **`graph TD`** or **`graph TB`** - Top to Bottom (vertical flow)
- **`graph BT`** - Bottom to Top (rarely used)

**Recommendation**: Use `graph LR` for hierarchical structures with many leaf nodes.

### 2. Parallel vs Sequential Connections

**Wrong - Sequential (creates a chain):**
```mermaid
Category --> Item1
Item1 --> Item2
Item2 --> Item3
```

**Correct - Parallel (independent items):**
```mermaid
Category --> Item1
Category --> Item2
Category --> Item3
```

### 3. Three-Level Hierarchy Pattern

```mermaid
graph LR
    ROOT[Project/Module]

    ROOT --> CATEGORY1[Category 1]
    CATEGORY1 --> ITEM1[Item 1.1]
    CATEGORY1 --> ITEM2[Item 1.2]
    CATEGORY1 --> ITEM3[Item 1.3]

    ROOT --> CATEGORY2[Category 2]
    CATEGORY2 --> ITEM4[Item 2.1]
    CATEGORY2 --> ITEM5[Item 2.2]
```

## Color Coding

Apply consistent colors using the `style` directive:

```mermaid
style NodeID fill:#color-hex
```

**Recommended color scheme:**
- Categories: Darker, saturated colors (e.g., `#bbdefb`, `#ffe0b2`, `#c8e6c9`)
- Items: Lighter, matching colors (e.g., `#e3f2fd`, `#fff3e0`, `#e8f5e9`)

## Multi-line Text in Nodes

Use `<br/>` for line breaks:

```mermaid
graph LR
    A["File Name<br/>Description line 1<br/>Description line 2"]
```

For file trees, use Unicode box-drawing characters:
```mermaid
graph LR
    A["Category (3 files)<br/>--- file1.ts<br/>--- file2.ts<br/>--- file3.ts"]
```

## Complete Example

```mermaid
graph LR
    ROOT["notion-paper-sync/"]

    ROOT --> UNIT["Unit Tests (25 files)"]
    UNIT --> U1["lib/crypto/encryption.test.ts"]
    UNIT --> U2["lib/process/markdown.test.ts"]
    UNIT --> U3["lib/url.test.ts"]

    ROOT --> INTEGRATION["Integration Tests (40 files)"]
    INTEGRATION --> I1["composio-notion-basic.test.ts"]
    INTEGRATION --> I2["remarkable-cloud-list.test.ts"]
    INTEGRATION --> I3["extract-content-openai.test.ts"]

    ROOT --> HELPERS["Test Helpers (11 files)"]
    HELPERS --> H1["cleanup-test-resources.ts"]
    HELPERS --> H2["test-env.ts"]

    style UNIT fill:#bbdefb
    style INTEGRATION fill:#ffe0b2
    style HELPERS fill:#c8e6c9
    style U1 fill:#e3f2fd
    style U2 fill:#e3f2fd
    style U3 fill:#e3f2fd
    style I1 fill:#fff3e0
    style I2 fill:#fff3e0
    style I3 fill:#fff3e0
    style H1 fill:#e8f5e9
    style H2 fill:#e8f5e9
```

## Common Pitfalls

1. **Using subgraphs for leaf nodes**: Subgraphs group nodes visually but can cause horizontal spreading. Use direct connections instead.

2. **Forgetting graph direction**: Always specify `LR`, `TD`, or `TB` - it dramatically affects layout.

3. **Chaining nodes unnecessarily**: Only chain nodes if they have actual dependencies or sequential flow.

4. **Inconsistent node IDs**: Use clear, descriptive IDs like `UNIT_TEST_1` not just `A`, `B`, `C`.

## Skill Activation

This skill activates when:
- Creating diagrams to visualize hierarchies
- User asks for a "diagram", "visualization", or "mermaid"
- Documenting file structures, test suites, or component relationships
- User provides data that would benefit from visual representation

## Resources

- [Mermaid Documentation](https://mermaid.js.org/intro/)
- [Mermaid Live Editor](https://mermaid.live/) - Test your diagrams
- [Color Picker](https://materialui.co/colors) - Material Design colors work well
