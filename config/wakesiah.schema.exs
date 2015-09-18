[
  mappings: [
    "logger.console.level": [
      doc: "Provide documentation for logger.console.level here.",
      to: "logger.console.level",
      datatype: :atom,
      default: :info
    ],
    "logger.console.format": [
      doc: "Provide documentation for logger.console.format here.",
      to: "logger.console.format",
      datatype: :binary,
      default: "$date $time [$level] $message\n"
    ],
    "logger.backends": [
      doc: "Provide documentation for logger.backends here.",
      to: "logger.backends",
      datatype: [
        list: :atom
      ],
      default: [
        :console
      ]
    ],
    "logger.level": [
      doc: "Provide documentation for logger.level here.",
      to: "logger.level",
      datatype: :atom,
      default: :debug
    ]
  ],
  translations: [
  ]
]
