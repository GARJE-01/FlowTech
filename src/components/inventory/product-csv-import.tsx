"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Upload, FileUp, Download } from "lucide-react"
import Papa from "papaparse"
import { importProductsFromCSV } from "@/actions/inventory"
// Re-checking imports from supplier-csv-import: it used 'alert'. I will use 'alert' for consistency or 'sonner' if I see it. 
// Actually, let's look at `supplier-csv-import` again. It used `alert`.
// I'll stick to `alert` for now to be safe, or just standard UI feedback.

export function ProductCSVImport() {
    const [loading, setLoading] = useState(false);

    const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (!file) return;

        setLoading(true);
        Papa.parse(file, {
            header: true,
            skipEmptyLines: true,
            complete: async (results) => {
                try {
                    const res = await importProductsFromCSV(results.data);
                    if (!res.success) {
                        alert("Import failed: " + res.error || "Unknown error");
                    } else {
                        let msg = `Successfully imported ${res.count} products.`;
                        if (res.errors && res.errors.length > 0) {
                            msg += `\n\n${res.errors.length} items skipped/failed.`;
                            console.warn("Import warning:", res.errors);
                        }
                        alert(msg);
                    }
                } catch (err) {
                    alert("An error occurred during import.");
                    console.error(err);
                } finally {
                    setLoading(false);
                    // Reset input
                    e.target.value = "";
                }
            },
            error: (err) => {
                alert("CSV Parse Error: " + err.message);
                setLoading(false);
            }
        });
    };

    const downloadTemplate = () => {
        const csvContent = "data:text/csv;charset=utf-8,"
            + "Name,Category,Description,BasePrice,SKU,VariantName,Price,Stock\n"
            + "Example Product,Electronics,Description here,100,EX-001,Standard,100,10";
        const encodedUri = encodeURI(csvContent);
        const link = document.createElement("a");
        link.setAttribute("href", encodedUri);
        link.setAttribute("download", "product_import_template.csv");
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    };

    return (
        <div className="flex gap-2 items-center">
            <Button variant="outline" size="sm" onClick={downloadTemplate} title="Download Template">
                <Download className="mr-2 h-4 w-4" />
                Template
            </Button>
            <div className="relative">
                <input
                    type="file"
                    accept=".csv"
                    className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
                    onChange={handleFileUpload}
                    disabled={loading}
                />
                <Button variant="default" size="sm" disabled={loading}>
                    {loading ? <Upload className="mr-2 h-4 w-4 animate-spin" /> : <FileUp className="mr-2 h-4 w-4" />}
                    {loading ? "Importing..." : "Import CSV"}
                </Button>
            </div>
        </div>
    )
}
