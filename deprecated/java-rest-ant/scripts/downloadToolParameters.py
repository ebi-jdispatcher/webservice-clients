import urllib2
import xml.etree.ElementTree as ET
import glob

jdispatcherUrl = 'http://www.ebi.ac.uk/Tools/services/rest/'
resourcesPath = '../resources/'


def format_string(input):
    """ Remove whitespaces and xml annotations """

    # Remove xml annotation from input_format
    input = input.replace('xsd:', '')

    # Replace whitespaces with spaces
    input = " ".join(input.split())

    # Strip the output
    return input.strip()


def download_wadl(tool_name):
    """Download wadl file for a given tool name """

    wadl = urllib2.urlopen(jdispatcherUrl + tool_name + "?wadl").read()
    with open(resourcesPath + tool_name + ".wadl", "w") as text_file:
        text_file.write(wadl)


def append_spaces_to(array):
    """ Append spaces to names and input_formats (types) to get length of the longest one plus margin """
    longest_name = len(max([x[0] for x in array], key=len)) + 1
    longest_type = len(max([x[1] for x in array], key=len)) + 1

    for idx, item in enumerate(array):

        # tuple as list (tuple is immutable)
        element = list(item)

        if len(element[0]) < longest_name:
            element[0] += ' ' * (longest_name - len(element[0]))

        if len(element[1]) < longest_type:
            element[1] += ' ' * (longest_type - len(element[1]))

        array[idx] = tuple(element)


def append_legend(array):
    """ Print additional information about parameters below parameter list """
    if len([x for x in array if x[1].startswith('ArrayOfString')]) > 0:
        array.append(('\nArrayOfString is a comma separated list of elements or just one element.', '', ''))


def process_wadl(tool):
    """Generate list of required and optional parameters for a given tool name """

    input = resourcesPath + tool + '.wadl'
    reqout = resourcesPath + tool + '_required.txt'
    optout = resourcesPath + tool + '_optional.txt'

    try:
        tree = ET.parse(input)
    except ET.ParseError:
        print "Can not parse tool: " + tool
        return

    required = []
    optional = []

    # Hard-code the 'sequence' parameter as required
    required.append(('--sequence', 'string', 'Path to a sequence file or the sequence string.'))

    params = tree.findall('./*/representation_type/')

    for param in params:

        attrib = param.attrib
        description = param.findtext("*")

        tool_name = format_string('--' + attrib['name'])
        input_format = format_string(attrib['type'])
        description = format_string(description)

        ptuple = (tool_name, input_format, description)

        # sequence is hardcoded as a required parameter in java
        if tool_name.startswith('sequence'):
            continue

        if attrib['required'] == 'true':
            required.append(ptuple)
        else:
            if tool_name == '--sequence':
                continue
            optional.append(ptuple)

    append_spaces_to(required)
    append_spaces_to(optional)

    # append_legend(required)
    # append_legend(optional)

    f = open(reqout, "w")
    f.write('\n'.join('%s\t%s\t%s' % x for x in required))
    f.close()

    f = open(optout, "w")
    f.write('\n'.join('%s\t%s\t%s' % x for x in optional))
    f.close()


def process_all_wadl_files():
    """ Iterate through wadl files in the resources/ and generate {}_optional.txt and {}_required.txt parameter files"""

    downloaded_wadls = glob.glob(resourcesPath + '*.wadl')
    for wadl_path in downloaded_wadls:
        wadl_name = wadl_path.replace(resourcesPath, '').replace('.wadl', '')
        process_wadl(wadl_name)


def download_all_tool_info():
    """ Download tools.xml and generate <toolName>.info file for each tool with its id, name and description """
    tools_as_xml = urllib2.urlopen(jdispatcherUrl + "/tools").read()
    with open(resourcesPath + "tools.xml", "w") as xml_file:
        xml_file.write(tools_as_xml)

    root = ET.fromstring(tools_as_xml)

    for tool in root:
        tool_id = tool.find('id').text
        tool_name = tool.find('name').text
        tool_desc = tool.find('description').text
        # Download wadl
        download_wadl(tool_id)

        f = open(resourcesPath + tool_id + ".info", "w")
        f.write(tool_id + '\n' + tool_name + '\n' + tool_desc)
        f.close()


if __name__ == '__main__':
    download_all_tool_info()
    process_all_wadl_files()




