
set(ODB_COMPILE_DEBUG FALSE)
set(ODB_COMPILE_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/odb_gen")
set(ODB_COMPILE_HEADER_SUFFIX ".h")
set(ODB_COMPILE_INLINE_SUFFIX "_inline.h")
set(ODB_COMPILE_SOURCE_SUFFIX ".cpp")
set(ODB_COMPILE_FILE_SUFFIX "_odb")

set(CMAKE_INCLUDE_CURRENT_DIR TRUE)

function(odb_compile outvar)
	if(NOT ODB_EXECUTABLE)
		message(FATAL_ERROR "odb compiler executable not found")
	endif()

	set(options GENERATE_QUERY GENERATE_SESSION GENERATE_SCHEMA GENERATE_PREPARED)
	set(oneValueParams SCHEMA_FORMAT SCHEMA_NAME TABLE_PREFIX
		STANDARD SLOC_LIMIT
		HEADER_PROLOGUE INLINE_PROLOGUE SOURCE_PROLOGUE
		HEADER_EPILOGUE INLINE_EPILOGUE SOURCE_EPILOGUE
		MULTI_DATABASE
		PROFILE)
	set(multiValueParams FILES INCLUDE DB)

	cmake_parse_arguments(PARAM "${options}" "${oneValueParams}" "${multiValueParams}" ${ARGN})

	if(PARAM_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "invalid arguments passed to odb_wrap_cpp: ${PARAM_UNPARSED_ARGUMENTS}")
	endif()

	if(NOT PARAM_FILES)
		message(FATAL_ERROR: "no input files to odb_compile")
	endif()

	set(ODB_ARGS)

	if(PARAM_MULTI_DATABASE)
		list(APPEND ODB_ARGS --multi-database "${PARAM_MULTI_DATABASE}")
	endif()

	foreach(db ${PARAM_DB})
		list(APPEND ODB_ARGS --database "${db}")
	endforeach()

	if(PARAM_GENERATE_QUERY)
		list(APPEND ODB_ARGS --generate-query)
	endif()

	if(PARAM_GENERATE_SESSION)
		list(APPEND ODB_ARGS --generate-session)
	endif()

	if(PARAM_GENERATE_SCHEMA)
		list(APPEND ODB_ARGS --generate-schema)
	endif()

	if(PARAM_GENERATE_PREPARED)
		list(APPEND ODB_ARGS --generate-prepared)
	endif()

	if(PARAM_SCHEMA_FORMAT)
		list(APPEND ODB_ARGS --schema-format "${PARAM_SCHEMA_FORMAT}")
	endif()

	if(PARAM_SCHEMA_NAME)
		list(APPEND ODB_ARGS --schema-name "${PARAM_SCHEMA_NAME}")
	endif()

	if(PARAM_TABLE_PREFIX)
		list(APPEND ODB_ARGS --table-prefix "${PARAM_TABLE_PREFIX}")
	endif()

	if(PARAM_STANDARD)
		list(APPEND ODB_ARGS --std "${PARAM_STANDARD}")
	endif()

	if(PARAM_SLOC_LIMIT)
		list(APPEND ODB_ARGS --sloc-limit "${PARAM_SLOC_LIMIT}")
	endif()

	if(PARAM_HEADER_PROLOGUE)
		list(APPEND ODB_ARGS --hxx-prologue-file "${PARAM_HEADER_PROLOGUE}")
	endif()

	if(PARAM_INLINE_PROLOGUE)
		list(APPEND ODB_ARGS --ixx-prologue-file "${PARAM_INLINE_PROLOGUE}")
	endif()

	if(PARAM_SOURCE_PROLOGUE)
		list(APPEND ODB_ARGS --cxx-prologue-file "${PARAM_SOURCE_PROLOGUE}")
	endif()

	if(PARAM_HEADER_EPILOGUE)
		list(APPEND ODB_ARGS --hxx-epilogue-file "${PARAM_HEADER_EPILOGUE}")
	endif()

	if(PARAM_INLINE_EPILOGUE)
		list(APPEND ODB_ARGS --ixx-epilogue-file "${PARAM_INLINE_EPILOGUE}")
	endif()

	if(PARAM_SOURCE_EPILOGUE)
		list(APPEND ODB_ARGS --cxx-epilogue-file "${PARAM_SOURCE_EPILOGUE}")
	endif()

	if(PARAM_PROFILE)
		list(APPEND ODB_ARGS --profile "${PARAM_PROFILE}")
	endif()

	list(APPEND ODB_ARGS --output-dir "${ODB_COMPILE_OUTPUT_DIR}")
	list(APPEND ODB_ARGS --hxx-suffix "${ODB_COMPILE_HEADER_SUFFIX}")
	list(APPEND ODB_ARGS --ixx-suffix "${ODB_COMPILE_INLINE_SUFFIX}")
	list(APPEND ODB_ARGS --cxx-suffix "${ODB_COMPILE_SOURCE_SUFFIX}")
	list(APPEND ODB_ARGS --odb-file-suffix "${ODB_COMPILE_FILE_SUFFIX}")

	foreach(dir ${PARAM_INCLUDE} ${ODB_INCLUDE_DIRS})
		list(APPEND ODB_ARGS "-I${dir}")
	endforeach()

	file(REMOVE_RECURSE "${ODB_COMPILE_OUTPUT_DIR}")
	file(MAKE_DIRECTORY "${ODB_COMPILE_OUTPUT_DIR}")

	foreach(input ${PARAM_FILES})
		get_filename_component(output "${input}" NAME_WE)
		set(output "${ODB_COMPILE_OUTPUT_DIR}/${output}${ODB_COMPILE_FILE_SUFFIX}${ODB_COMPILE_SOURCE_SUFFIX}")

		list(APPEND ${outvar} "${output}")

		if(ODB_COMPILE_DEBUG)
			set(_msg "${ODB_EXECUTABLE} ${ODB_ARGS} ${input}")
			string(REPLACE ";" " " _msg "${_msg}")
			message(STATUS "${_msg}")
		endif()

		add_custom_command(OUTPUT "${output}"
			COMMAND ${ODB_EXECUTABLE} ${ODB_ARGS} "${input}"
			DEPENDS "${input}"
			WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
			VERBATIM)
	endforeach()

	set(${outvar} ${${outvar}} PARENT_SCOPE)
endfunction()
