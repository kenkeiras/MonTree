const assert = require('assert');
const dependency_graph = require('../js/dependency_graph.js');

describe('Dependency graph', function() {
    it('Simple two level graph, no loops', function() {
        const input = [
            {
                "id":3,
                "dependencies":[2]
            },
            {
                "id":2,
                "dependencies":[1]
            },
            {
                "id":4,
                "dependencies":[1,2,3]
            },
            {
                "id":1,
                "dependencies":[]
            }
        ];

        /** 
         * Expected result
         * 
         *       /------↓
         *  1 → 2 → 3 → 4
         *   \----------↑   
         */

        const output = [
            [
                {
                    "id":1,
                    "dependencies":[],
                    "depended_by":[2, 4]
                }
            ],
            [
                {
                    "id":2,
                    "dependencies":[1],
                    "depended_by":[3, 4]
                },
            ],
            [
                {
                    "id":3,
                    "dependencies":[2],
                    "depended_by":[4]
                },
            ],
            [
                {
                    "id":4,
                    "dependencies":[1,2,3],
                    "depended_by":[]
                }
            ]
        ];

        assert.deepEqual(dependency_graph.sort_by_dependency_columns(input), output);
    });

    it('Single element, no dependencies', function() {
        const input = [
            {
                "id":1,
                "dependencies":[]
            }
        ];

        /** 
         * Expected result
         * 
         *  1
         *
         */

        const output = [
            [
                {
                    "id":1,
                    "dependencies":[],
                    "depended_by":[]
                }
            ]
        ];

        assert.deepEqual(dependency_graph.sort_by_dependency_columns(input), output);
    });

    it('Two elements in a loop, no element undepended', function() {
        const input = [
            {
                "id":1,
                "dependencies":[2]
            },
            {
                "id":2,
                "dependencies":[1]
            }
        ];

        /** 
         * Expected result
         * 
         * 1
         * ↓↑
         * 2
         * 
         */

        const output = [
            [
                {
                    "id":1,
                    "dependencies":[2],
                    "depended_by":[] // Circular dependencies are removed
                },
                {
                    "id":2,
                    "dependencies":[1],
                    "depended_by":[] // Circular dependencies are removed
                }
            ]
        ];

        assert.deepEqual(dependency_graph.sort_by_dependency_columns(input), output);
    });

    it('Three elements in a loop, no element undepended', function() {
        const input = [
            {
                "id":1,
                "dependencies":[2]
            },
            {
                "id":2,
                "dependencies":[3]
            },
            {
                "id":3,
                "dependencies":[1]
            }
        ];

        /** 
         * Expected result
         * 
         *  1←\
         *  ↓ |
         *  2 |
         *  ↓ |
         *  3-/
         * 
         */

        const output = [
            [
                {
                    "id":1,
                    "dependencies":[2],
                    "depended_by":[] // Circular dependencies are removed
                },
                {
                    "id":2,
                    "dependencies":[3],
                    "depended_by":[] // Circular dependencies are removed
                },
                {
                    "id":3,
                    "dependencies":[1],
                    "depended_by":[] // Circular dependencies are removed
                }
            ]
        ];

        assert.deepEqual(dependency_graph.sort_by_dependency_columns(input), output);
    });
});