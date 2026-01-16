// Project imports:
import 'package:dashboardpro/dashboardpro.dart';

class AccordionScreen extends StatelessWidget {
  const AccordionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return UniversalDash(
      title: AppBarTitle.accordion,
      isSubMenu: true,
      mainMenu: AppBarTitle.base,
      body: bodyWidget(context: context),
    );
  }

  Widget bodyWidget({required BuildContext context}) {
    String text = """Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.""";
    return Card(
      child: AccordionWidgets(
        items: [
          AccordionItem(
            header: 'What is Lorem Ipsum?',
            body: Text(text),
          ),
          AccordionItem(
            header: 'Why do we use it?',
            body: Text(text),
          ),
          AccordionItem(
            header: 'Where does it come from?',
            body: Text(text),
          ),
          AccordionItem(
            header: 'Where can I get some?',
            body: Text(text),
          ),
          AccordionItem(
            header: 'Why do we use it?',
            body: Text(text),
          ),
          AccordionItem(
            header: 'Where does it come from?',
            body: Text(text),
          ),
        ],
      ),
    );
  }
}
