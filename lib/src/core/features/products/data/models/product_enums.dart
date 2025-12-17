enum ProductBillingType {
  oneTime('Valor Único'),
  subscription('Assinatura mensal');

  const ProductBillingType(this.label);
  final String label;
}

enum ProductCategory {
  appsAndSoftware('Apps & Software'),
  marketplace('Marketplace'),
  infoProduct('Infoproduto'),
  courses('Cursos'),
  healthAndSports('Saúde e Esportes'),
  financeAndInvestments('Finanças e Investimentos'),
  relationships('Relacionamentos'),
  businessAndCareer('Negócios e Carreira'),
  spirituality('Espiritualidade'),
  sexuality('Sexualidade'),
  entertainment('Entretenimento'),
  cookingAndGastronomy('Culinária e Gastronomia'),
  languages('Idiomas'),
  law('Direito'),
  literature('Literatura'),
  homeAndConstruction('Casa e Construção'),
  personalDevelopment('Desenvolvimento Pessoal'),
  fashionAndBeauty('Moda e Beleza'),
  animalsAndPlants('Animais e Plantas'),
  educational('Educacional'),
  hobbies('Hobbies'),
  design('Design'),
  internet('Internet'),
  ecologyAndEnvironment('Ecologia e Meio Ambiente'),
  musicAndArts('Música e Artes'),
  informationTechnology('Tecnologia da Informação'),
  digitalEntrepreneurship('Empreendedorismo Digital'),
  others('Outros');

  const ProductCategory(this.label);
  final String label;
}

enum ProductType {
  infoProduct('Curso Livre (infoproduto)'),
  ebook('Ebook'),
  extensionCourse('Curso de Extensão'),
  postgraduate('Pós-Graduação'),
  other('Outros');

  const ProductType(this.label);
  final String label;
}