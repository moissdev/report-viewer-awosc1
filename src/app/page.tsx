// src/app/page.tsx
import Link from 'next/link';

export default function Home() {
  const reports = [
    { id: 1, title: "Libros Más Prestados", desc: "Ranking general. (Soporta búsqueda y paginación)" },
    { id: 2, title: "Préstamos Vencidos", desc: "Atrasos y multas calculadas. (Filtro por días y paginación)" },
    { id: 3, title: "Resumen de Multas", desc: "Ingresos mensuales por multas cobradas y pendientes." },
    { id: 4, title: "Actividad de Socios", desc: "Usuarios activos y su tasa de morosidad." },
    { id: 5, title: "Salud del Inventario", desc: "Estado físico de las copias por categoría." },
  ];

  return (
    <main className="min-h-screen p-10 bg-slate-50">
      <h1 className="text-4xl font-bold mb-8 text-center text-slate-800">
        Dashboard de Biblioteca
      </h1>
      
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 max-w-6xl mx-auto">
        {reports.map((report) => (
          <Link 
            href={`/reports/${report.id}`} 
            key={report.id}
            className="block p-6 bg-white rounded-xl shadow-sm hover:shadow-md transition-shadow border border-slate-200"
          >
            <div className="flex items-center justify-between mb-4">
              <span className="bg-indigo-100 text-indigo-800 text-xs font-bold px-3 py-1 rounded-full">
                Reporte #{report.id}
              </span>
            </div>
            <h2 className="text-xl font-semibold mb-2 text-slate-800">{report.title}</h2>
            <p className="text-slate-600 text-sm">{report.desc}</p>
          </Link>
        ))}
      </div>
    </main>
  );
}