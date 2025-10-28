const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting database seeding...');

  // // Clear existing data to avoid conflicts
  await prisma.productImage.deleteMany();
  await prisma.product.deleteMany();
  await prisma.category.deleteMany();
  await prisma.user.deleteMany();

  // Создаем категории с реальными ссылками на изображения
  const categoriesData = [
    {
      name: 'Десерты',
      description: 'Вкусные десерты для настоящих сладкоежек',
      image_url: 'https://avatars.mds.yandex.net/i?id=071c44cbc8e6e6af580716a925ed0e4a_l-8497596-images-thumbs&n=13',
    },
    {
      name: 'Кофе',
      description: 'Свежеобжаренный кофе и кофейные напитки',
      image_url: 'https://avatars.mds.yandex.net/i?id=3fe8bbc1574db4682ee95db59a543df7_l-12992035-images-thumbs&n=13',
    },
    {
      name: 'Торты',
      description: 'Праздничные и повседневные торты',
      image_url: 'https://cdn.culture.ru/images/ee686c5b-7773-53a6-8e81-dd4b3f03f09a',
    },
    {
      name: 'Пирожные',
      description: 'Нежные и воздушные пирожные',
      image_url: 'https://cdn.prod.website-files.com/625ed727ba6052c9183898d8/6703b8d823c929732e76f803_Sweets_med.jpg',
    },
  ];

  // Create categories one by one to get their IDs
  const createdCategories = [];
  for (const categoryData of categoriesData) {
    const category = await prisma.category.create({
      data: categoryData,
    });
    createdCategories.push(category);
  }

  console.log(`✅ Created ${createdCategories.length} categories`);

  // Создаем администратора
  const adminPasswordHash = await bcrypt.hash('admin123', 12);
  const admin = await prisma.user.upsert({
    where: { email: 'admin@dessertshop.com' },
    update: {},
    create: {
      email: 'admin@dessertshop.com',
      password_hash: adminPasswordHash,
      first_name: 'Admin',
      phone_number: '+79998887766',
      role: 'admin',
      email_verified: true,
      profile: {
        create: {
          preferred_notifications: true,
        },
      },
    },
  });

  console.log('✅ Created admin user');

  // Создаем тестовые товары с правильными category_id
  const productsData = [
    {
      name: 'Тирамису классический',
      description: 'Нежный итальянский десерт с кофейным вкусом',
      full_description: 'Классический тирамису с mascarpone, савоярди и espresso. Идеальное сочетание нежного крема и кофейной пропитки.',
      price: 350.00,
      category_id: createdCategories[0].id, // Десерты
      weight_grams: 150,
      calories: 280,
      ingredients: ['mascarpone', 'савоярди', 'espresso', 'яйца', 'сахар', 'какао'],
      tags: ['итальянский', 'кофейный', 'классический'],
      sort_order: 1,
    },
    {
      name: 'Чизкейк Нью-Йорк',
      description: 'Классический чизкейк с нежной текстурой',
      full_description: 'Настоящий нью-йоркский чизкейк на основе творожного сыра с ванильным вкусом и песочным основанием.',
      price: 420.00,
      category_id: createdCategories[0].id, // Десерты
      weight_grams: 200,
      calories: 320,
      ingredients: ['творожный сыр', 'сливки', 'яйца', 'сахар', 'песочное тесто', 'ваниль'],
      tags: ['классический', 'сырный', 'американский'],
      sort_order: 2,
    },
    {
      name: 'Латте',
      description: 'Кофе с молоком и нежной пенкой',
      full_description: 'Сбалансированный напиток на основе эспрессо и вспененного молока.',
      price: 180.00,
      category_id: createdCategories[1].id, // Кофе
      volume_ml: 300,
      calories: 120,
      ingredients: ['эспрессо', 'молоко'],
      tags: ['кофе', 'молочный', 'классический'],
      sort_order: 1,
    },
    {
      name: 'Капучино',
      description: 'Кофе с плотной молочной пенкой',
      full_description: 'Итальянский кофейный напиток с равными пропорциями эспрессо, молока и молочной пены.',
      price: 160.00,
      category_id: createdCategories[1].id, // Кофе
      volume_ml: 180,
      calories: 110,
      ingredients: ['эспрессо', 'молоко'],
      tags: ['кофе', 'пенка', 'итальянский'],
      sort_order: 2,
    },
  ];

  // Create products one by one to get their IDs
  const createdProducts = [];
  for (const productData of productsData) {
    const product = await prisma.product.create({
      data: productData,
    });
    createdProducts.push(product);
  }

  console.log(`✅ Created ${createdProducts.length} products`);

  // Создаем изображения для товаров с реальными ссылками
  const productImagesData = [
    {
      product_id: createdProducts[0].id, // Тирамису
      image_url: 'https://img-s-msn-com.akamaized.net/tenant/amp/entityid/AA1H7gbo.img?w=1000&h=707&m=4&q=99',
      alt_text: 'Тирамису классический',
      sort_order: 0,
    },
    {
      product_id: createdProducts[1].id, // Чизкейк
      image_url: 'https://santokuknives.co.uk/cdn/shop/articles/Cheesecake_200_300-710217.jpg?v=1716638859',
      alt_text: 'Чизкейк Нью-Йорк',
      sort_order: 0,
    },
    {
      product_id: createdProducts[2].id, // Латте
      image_url: 'https://avatars.mds.yandex.net/i?id=3df7e572e976e0db22272cba0f9799f5_l-4298511-images-thumbs&n=13',
      alt_text: 'Латте',
      sort_order: 0,
    },
    {
      product_id: createdProducts[3].id, // Капучино
      image_url: 'https://angelinos.com/cdn/shop/articles/How_Much_Milk_Coffee_in_a_Cappuccino.jpg?v=1701189122',
      alt_text: 'Капучино',
      sort_order: 0,
    },
  ];

  await prisma.productImage.createMany({
    data: productImagesData,
    skipDuplicates: true,
  });

  console.log('✅ Created product images');

  console.log('🎉 Database seeding completed!');
}

main()
  .catch((e) => {
    console.error('❌ Seeding error:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });