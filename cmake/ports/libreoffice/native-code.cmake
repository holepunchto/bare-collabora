execute_process(
  COMMAND python3 "${SOURCE_DIR}/solenv/bin/native-code.py"
    -C
    -g core
    -g writer
    -g calc
    -g draw
    -g edit
  OUTPUT_FILE "${OUTPUT}"
  RESULT_VARIABLE result
)

if(NOT result EQUAL 0)
  file(REMOVE "${OUTPUT}")

  message(FATAL_ERROR "native-code.py failed with exit code ${result}")
endif()
