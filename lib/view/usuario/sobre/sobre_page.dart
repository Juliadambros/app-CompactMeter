import 'package:flutter/material.dart';

class SobreProjetoPage extends StatelessWidget {
  const SobreProjetoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sobre o CompactMeter"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "CompactMeter",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              "CompactMeter é um projeto desenvolvido na Universidade Estadual do Centro-Oeste (UNICENTRO), "
              "com foco em pesquisa aplicada à mecanização agrícola e à agricultura de precisão.\n\n"
              "A iniciativa integra conhecimentos das áreas de Agronomia e Ciência da Computação e Big Data no Agronegócio, "
              "visando o desenvolvimento de soluções tecnológicas para coleta, análise e acompanhamento de dados "
              "relacionados ao desempenho de máquinas agrícolas.\n\n"
              "O projeto é vinculado ao Núcleo de Mecanização e Agricultura de Precisão (NMAP), "
              "que desenvolve pesquisas voltadas à mecanização agrícola e à agricultura de precisão, "
              "promovendo a integração entre tecnologia, pesquisa científica e aplicação prática no campo.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 30),

            const Text(
              "Fórmulas Matemáticas Utilizadas",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "As fórmulas matemáticas utilizadas no CompactMeter serão descritas nesta seção. ",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 30),

            const Text(
              "Equipe do Projeto",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "• Júlia Dambrós – Estudante de Ciência da Computação\n"
              "• Alexandre Martins – Estudante de Big Data no Agronegócio",
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            const Text(
              "Professores / Pesquisadores",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "• Dr. Jotair Elio Kwiatkowski Junior\n"
              "• Dr. Mauro Miazaki\n"
              "• Dr. Leandro Rampim",
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 30),

            const Text(
              "Instituições e Departamentos",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Wrap(
              alignment: WrapAlignment.center,
              spacing: 20,
              runSpacing: 20,
              children: [
                _buildLogo("assets/imgs/agronomia.png"),
                _buildLogo("assets/imgs/logobigdata.png"),
                _buildLogo("assets/imgs/logo_CienciaComputacao.png"),
                _buildLogo("assets/imgs/nmap.png"),
                _buildLogo("assets/imgs/unicentro.png"),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(String path) {
    return SizedBox(
      width: 100,
      child: Image.asset(
        path,
        fit: BoxFit.contain,
      ),
    );
  }
}
